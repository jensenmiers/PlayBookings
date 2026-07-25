import { render, screen } from '@testing-library/react'

jest.mock('next/navigation', () => ({
  notFound: jest.fn(() => {
    throw new Error('NEXT_NOT_FOUND')
  }),
}))

import BrandConceptRoute, {
  generateMetadata,
  generateStaticParams,
} from '../page'
import { notFound } from 'next/navigation'

const mockNotFound = notFound as jest.MockedFunction<typeof notFound>

describe('BrandConceptRoute', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('prebuilds exactly the three review concepts', () => {
    expect(generateStaticParams()).toEqual([
      { concept: '1' },
      { concept: '2' },
      { concept: '3' },
    ])
  })

  it.each([
    ['1', /tune, don.t rebrand/i, /green still closes the booking/i],
    ['2', /two-speed brand/i, /orange gets attention/i],
    ['3', /orange-first relaunch/i, /play louder/i],
  ])(
    'renders concept %s with shared comparison controls',
    async (concept, heading, signatureCopy) => {
      const result = await BrandConceptRoute({
        params: Promise.resolve({ concept }),
      })

      render(result)

      expect(screen.getByRole('heading', { name: heading, level: 1 })).toBeInTheDocument()
      expect(screen.getByText(signatureCopy)).toBeInTheDocument()
      expect(
        screen.getByRole('navigation', { name: /brand concept switcher/i })
      ).toBeInTheDocument()
      expect(screen.getByRole('link', { name: /concept 1/i })).toHaveAttribute(
        'href',
        '/brand-concepts/1'
      )
      expect(screen.getByRole('link', { name: /concept 2/i })).toHaveAttribute(
        'href',
        '/brand-concepts/2'
      )
      expect(screen.getByRole('link', { name: /concept 3/i })).toHaveAttribute(
        'href',
        '/brand-concepts/3'
      )
      expect(screen.getByRole('heading', { name: /courts near you/i, level: 2 })).toBeInTheDocument()
      expect(screen.getAllByText(/private rental/i).length).toBeGreaterThan(0)
      expect(screen.getAllByText(/open gym/i).length).toBeGreaterThan(0)
    }
  )

  it('keeps the review-only concepts out of search indexes', async () => {
    const metadata = await generateMetadata({
      params: Promise.resolve({ concept: '2' }),
    })

    expect(metadata.title).toMatch(/two-speed brand/i)
    expect(metadata.robots).toEqual({ index: false, follow: false })
  })

  it('returns not found for any route outside concepts 1 through 3', async () => {
    await expect(
      BrandConceptRoute({
        params: Promise.resolve({ concept: '4' }),
      })
    ).rejects.toThrow('NEXT_NOT_FOUND')

    expect(mockNotFound).toHaveBeenCalled()
  })
})
